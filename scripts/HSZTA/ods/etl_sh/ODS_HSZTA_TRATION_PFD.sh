#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TRATION_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TRATION_PFD_TMP(
  C_RATIONNO  STRING  COMMENT  '定期定额协议号',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARETYPE  STRING  COMMENT  '份额类型',
  D_DATE  STRING  COMMENT  '申请日期',
  C_REQUESTNO  STRING  COMMENT  '申请编号',
  C_RATIONTYPE  STRING  COMMENT  '定期定额类型',
  F_BALANCE  DECIMAL(16,2)  COMMENT  '申购金额',
  F_SHARES  DECIMAL(16,2)  COMMENT  '赎回份额',
  L_RATIONDATE  DECIMAL(10,0)  COMMENT  '定期日期',
  C_RATIONTERM  STRING  COMMENT  '定期定额周期',
  D_PROTOCOLENDDATE  STRING  COMMENT  '协议截止日期',
  L_DELAY  DECIMAL(10,0)  COMMENT  '允许顺延天数',
  L_ALLOWFAIL  DECIMAL(10,0)  COMMENT  '允许失败的次数',
  D_LASTDATE  STRING  COMMENT  '数据最后导入日期',
  F_AGIO  DECIMAL(5,4)  COMMENT  '协议费用折扣',
  C_FLAG  STRING  COMMENT  '标志',
  L_TIMES  DECIMAL(10,0)  COMMENT  '累计实现次数',
  F_TOTALBALANCE  DECIMAL(16,2)  COMMENT  '累计申购实现金额',
  F_TOTALSHARES  DECIMAL(16,2)  COMMENT  '累计赎回实现份额',
  C_DEFAULT  STRING  COMMENT  '默认协议',
  D_LASTREQUESTDATE  STRING  COMMENT  '最后交易申请日期',
  F_REALAGIO  DECIMAL(5,4)  COMMENT  '上次实现折扣',
  D_FIRSTDATE  STRING  COMMENT  '首次交易确认日期',
  C_SYSROLE  STRING  COMMENT  '系统角色',
  F_RATIONRATIO  DECIMAL(5,4)  COMMENT  '',
  C_MEMO  STRING  COMMENT  ''
)
COMMENT '定期定额协议表'
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
              "querySql": ["SELECT  C_RATIONNO
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_FUNDCODE
                                   , C_SHARETYPE
                                   , D_DATE
                                   , C_REQUESTNO
                                   , C_RATIONTYPE
                                   , F_BALANCE
                                   , F_SHARES
                                   , L_RATIONDATE
                                   , C_RATIONTERM
                                   , D_PROTOCOLENDDATE
                                   , L_DELAY
                                   , L_ALLOWFAIL
                                   , D_LASTDATE
                                   , F_AGIO
                                   , C_FLAG
                                   , L_TIMES
                                   , F_TOTALBALANCE
                                   , F_TOTALSHARES
                                   , C_DEFAULT
                                   , D_LASTREQUESTDATE
                                   , F_REALAGIO
                                   , D_FIRSTDATE
                                   , C_SYSROLE
                                   , F_RATIONRATIO
                                   , C_MEMO
                                FROM ${hszta_src_schema}.TRATION"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_RATIONNO", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARETYPE", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "C_REQUESTNO", "type": "STRING"}, {"name": "C_RATIONTYPE", "type": "STRING"}, {"name": "F_BALANCE", "type": "DOUBLE"}, {"name": "F_SHARES", "type": "DOUBLE"}, {"name": "L_RATIONDATE", "type": "DOUBLE"}, {"name": "C_RATIONTERM", "type": "STRING"}, {"name": "D_PROTOCOLENDDATE", "type": "STRING"}, {"name": "L_DELAY", "type": "DOUBLE"}, {"name": "L_ALLOWFAIL", "type": "DOUBLE"}, {"name": "D_LASTDATE", "type": "STRING"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "L_TIMES", "type": "DOUBLE"}, {"name": "F_TOTALBALANCE", "type": "DOUBLE"}, {"name": "F_TOTALSHARES", "type": "DOUBLE"}, {"name": "C_DEFAULT", "type": "STRING"}, {"name": "D_LASTREQUESTDATE", "type": "STRING"}, {"name": "F_REALAGIO", "type": "DOUBLE"}, {"name": "D_FIRSTDATE", "type": "STRING"}, {"name": "C_SYSROLE", "type": "STRING"}, {"name": "F_RATIONRATIO", "type": "DOUBLE"}, {"name": "C_MEMO", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tration_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tration_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tration_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tration_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TRATION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TRATION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tration_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TRATION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_RATIONNO
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_FUNDCODE
     , C_SHARETYPE
     , D_DATE
     , C_REQUESTNO
     , C_RATIONTYPE
     , F_BALANCE
     , F_SHARES
     , L_RATIONDATE
     , C_RATIONTERM
     , D_PROTOCOLENDDATE
     , L_DELAY
     , L_ALLOWFAIL
     , D_LASTDATE
     , F_AGIO
     , C_FLAG
     , L_TIMES
     , F_TOTALBALANCE
     , F_TOTALSHARES
     , C_DEFAULT
     , D_LASTREQUESTDATE
     , F_REALAGIO
     , D_FIRSTDATE
     , C_SYSROLE
     , F_RATIONRATIO
     , C_MEMO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TRATION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TRATION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TRATION_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TRATION_PFD成功"
      exit 0
   fi
fi
