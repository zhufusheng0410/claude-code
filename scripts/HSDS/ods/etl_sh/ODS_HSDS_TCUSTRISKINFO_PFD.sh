#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSDS.ODS_HSDS_TCUSTRISKINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCUSTRISKINFO_PFD_TMP(
  VC_CUSTNO  STRING  COMMENT  '客户编号',
  C_CUSTTYPE  STRING  COMMENT  '客户类别',
  C_IDENTITYTYPE  STRING  COMMENT  '证件类型',
  VC_IDENTITYNO  STRING  COMMENT  '证件号码',
  VC_CUSTOMNAME  STRING  COMMENT  '客户姓名',
  EN_RISKSCORE  DECIMAL(6,2)  COMMENT  '问卷得分',
  C_CUSTRISKTYPE  STRING  COMMENT  '投资人风险承受能力',
  VC_OPERATORNO  STRING  COMMENT  '操作员',
  C_AUDITFLAG  STRING  COMMENT  '复核标志',
  VC_AUDITNO  STRING  COMMENT  '复核员',
  VC_REPLYDATE  STRING  COMMENT  '最后更新日期',
  VC_QUESTIONNAIRENO  STRING  COMMENT  '问卷编号',
  C_REPLYFLAG  STRING  COMMENT  '是否填写问卷',
  C_INVESTTARGET  STRING  COMMENT  '投资目的',
  C_INVESTTERM  STRING  COMMENT  '投资期限',
  C_INVESTEXPER  STRING  COMMENT  '投资经验',
  C_FINANCE  STRING  COMMENT  '财务状况',
  C_SHORTRISK  STRING  COMMENT  '短期风险',
  C_LONGRISK  STRING  COMMENT  '长期风险',
  C_LICFLAG  STRING  COMMENT  '授权标识',
  C_COPYFLAG  STRING  COMMENT  '复制标识',
  VC_SOURCECUSTNO  STRING  COMMENT  '源客户编号',
  VC_SOURCEFUNDACCO  STRING  COMMENT  '源基金账号',
  VC_EXPLAIN  STRING  COMMENT  '',
  C_FIXBUSINFLAG  STRING  COMMENT  '',
  VC_REJECTREASON  STRING  COMMENT  '',
  C_QUESTIONKIND  STRING  COMMENT  '',
  C_VOUCHERFLAG  STRING  COMMENT  '',
  C_SURVEYKEEPALIVE  STRING  COMMENT  '',
  VC_ENDDATE  STRING  COMMENT  '',
  VC_FUNDCODE  STRING  COMMENT  '',
  C_NEWCUSTRISKTYPE  STRING  COMMENT  '',
  VC_QUESTIONVERSION  STRING  COMMENT  '',
  VC_NEWQUESTIONVERSION  STRING  COMMENT  '',
  C_MINRISKFLAG  STRING  COMMENT  '',
  VC_MINRISKQUESTIONCONT  STRING  COMMENT  '',
  VC_ORIOPERATORNO  STRING  COMMENT  '',
  VC_MANAGERCODE  STRING  COMMENT  '',
  VC_NETNO  STRING  COMMENT  '',
  C_TRUST  STRING  COMMENT  ''
)
COMMENT '投资人风险问卷回复信息表'
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
            "username": "${hsds_username}",
            "password": "${hsds_password}",
            "connection": [{
              "querySql": ["SELECT  VC_CUSTNO\n                                   , C_CUSTTYPE\n                                   , C_IDENTITYTYPE\n                                   , VC_IDENTITYNO\n                                   , VC_CUSTOMNAME\n                                   , EN_RISKSCORE\n                                   , C_CUSTRISKTYPE\n                                   , VC_OPERATORNO\n                                   , C_AUDITFLAG\n                                   , VC_AUDITNO\n                                   , VC_REPLYDATE\n                                   , VC_QUESTIONNAIRENO\n                                   , C_REPLYFLAG\n                                   , C_INVESTTARGET\n                                   , C_INVESTTERM\n                                   , C_INVESTEXPER\n                                   , C_FINANCE\n                                   , C_SHORTRISK\n                                   , C_LONGRISK\n                                   , C_LICFLAG\n                                   , C_COPYFLAG\n                                   , VC_SOURCECUSTNO\n                                   , VC_SOURCEFUNDACCO\n                                   , VC_EXPLAIN\n                                   , C_FIXBUSINFLAG\n                                   , VC_REJECTREASON\n                                   , C_QUESTIONKIND\n                                   , C_VOUCHERFLAG\n                                   , C_SURVEYKEEPALIVE\n                                   , VC_ENDDATE\n                                   , VC_FUNDCODE\n                                   , C_NEWCUSTRISKTYPE\n                                   , VC_QUESTIONVERSION\n                                   , VC_NEWQUESTIONVERSION\n                                   , C_MINRISKFLAG\n                                   , VC_MINRISKQUESTIONCONT\n                                   , VC_ORIOPERATORNO\n                                   , VC_MANAGERCODE\n                                   , VC_NETNO\n                                   , C_TRUST\n                                FROM ${hsds_src_schema}.TCUSTRISKINFO"],
              "jdbcUrl": ["${hsds_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_CUSTNO", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "VC_IDENTITYNO", "type": "STRING"}, {"name": "VC_CUSTOMNAME", "type": "STRING"}, {"name": "EN_RISKSCORE", "type": "DOUBLE"}, {"name": "C_CUSTRISKTYPE", "type": "STRING"}, {"name": "VC_OPERATORNO", "type": "STRING"}, {"name": "C_AUDITFLAG", "type": "STRING"}, {"name": "VC_AUDITNO", "type": "STRING"}, {"name": "VC_REPLYDATE", "type": "STRING"}, {"name": "VC_QUESTIONNAIRENO", "type": "STRING"}, {"name": "C_REPLYFLAG", "type": "STRING"}, {"name": "C_INVESTTARGET", "type": "STRING"}, {"name": "C_INVESTTERM", "type": "STRING"}, {"name": "C_INVESTEXPER", "type": "STRING"}, {"name": "C_FINANCE", "type": "STRING"}, {"name": "C_SHORTRISK", "type": "STRING"}, {"name": "C_LONGRISK", "type": "STRING"}, {"name": "C_LICFLAG", "type": "STRING"}, {"name": "C_COPYFLAG", "type": "STRING"}, {"name": "VC_SOURCECUSTNO", "type": "STRING"}, {"name": "VC_SOURCEFUNDACCO", "type": "STRING"}, {"name": "VC_EXPLAIN", "type": "STRING"}, {"name": "C_FIXBUSINFLAG", "type": "STRING"}, {"name": "VC_REJECTREASON", "type": "STRING"}, {"name": "C_QUESTIONKIND", "type": "STRING"}, {"name": "C_VOUCHERFLAG", "type": "STRING"}, {"name": "C_SURVEYKEEPALIVE", "type": "STRING"}, {"name": "VC_ENDDATE", "type": "STRING"}, {"name": "VC_FUNDCODE", "type": "STRING"}, {"name": "C_NEWCUSTRISKTYPE", "type": "STRING"}, {"name": "VC_QUESTIONVERSION", "type": "STRING"}, {"name": "VC_NEWQUESTIONVERSION", "type": "STRING"}, {"name": "C_MINRISKFLAG", "type": "STRING"}, {"name": "VC_MINRISKQUESTIONCONT", "type": "STRING"}, {"name": "VC_ORIOPERATORNO", "type": "STRING"}, {"name": "VC_MANAGERCODE", "type": "STRING"}, {"name": "VC_NETNO", "type": "STRING"}, {"name": "C_TRUST", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsds_tcustriskinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsds_path}/ods_hsds_tcustriskinfo_pfd_tmp",
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

printf '%s' "$json_obj" > "${json_path}ods_hsds_tcustriskinfo_pfd_tmp.json"

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" "${json_path}ods_hsds_tcustriskinfo_pfd_tmp.json"

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSDS_TCUSTRISKINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSDS_TCUSTRISKINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsds_tcustriskinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCUSTRISKINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_CUSTNO
     , C_CUSTTYPE
     , C_IDENTITYTYPE
     , VC_IDENTITYNO
     , VC_CUSTOMNAME
     , EN_RISKSCORE
     , C_CUSTRISKTYPE
     , VC_OPERATORNO
     , C_AUDITFLAG
     , VC_AUDITNO
     , VC_REPLYDATE
     , VC_QUESTIONNAIRENO
     , C_REPLYFLAG
     , C_INVESTTARGET
     , C_INVESTTERM
     , C_INVESTEXPER
     , C_FINANCE
     , C_SHORTRISK
     , C_LONGRISK
     , C_LICFLAG
     , C_COPYFLAG
     , VC_SOURCECUSTNO
     , VC_SOURCEFUNDACCO
     , VC_EXPLAIN
     , C_FIXBUSINFLAG
     , VC_REJECTREASON
     , C_QUESTIONKIND
     , C_VOUCHERFLAG
     , C_SURVEYKEEPALIVE
     , VC_ENDDATE
     , VC_FUNDCODE
     , C_NEWCUSTRISKTYPE
     , VC_QUESTIONVERSION
     , VC_NEWQUESTIONVERSION
     , C_MINRISKFLAG
     , VC_MINRISKQUESTIONCONT
     , VC_ORIOPERATORNO
     , VC_MANAGERCODE
     , VC_NETNO
     , C_TRUST
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSDS.ODS_HSDS_TCUSTRISKINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSDS.ODS_HSDS_TCUSTRISKINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSDS_TCUSTRISKINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSDS_TCUSTRISKINFO_PFD成功"
      exit 0
   fi
fi
