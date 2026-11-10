#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD_TMP(
  C_CUSTNO  STRING  COMMENT  '客户编号',
  C_ACCOUNTTYPE  STRING  COMMENT  '账户类型',
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  D_OPENDATE  STRING  COMMENT  '账户开户日期',
  D_LASTMODIFY  STRING  COMMENT  '最后修改日期',
  C_ACCOSTATUS  STRING  COMMENT  '账号状态',
  C_FREEZECAUSE  STRING  COMMENT  '冻结原因',
  D_BACKDATE  STRING  COMMENT  '冻结截止日期',
  L_CHANGETIME  DECIMAL(10,0)  COMMENT  '基金转换次数',
  D_FIRSTINVEST  STRING  COMMENT  '首次投资日期',
  C_PASSWORD  STRING  COMMENT  '查询密码',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_ACCOUNTCARDID  STRING  COMMENT  ''
)
COMMENT '基金账号信息'
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
              "querySql": ["SELECT  C_CUSTNO
                                   , C_ACCOUNTTYPE
                                   , C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_CHILDNETNO
                                   , D_OPENDATE
                                   , D_LASTMODIFY
                                   , C_ACCOSTATUS
                                   , C_FREEZECAUSE
                                   , D_BACKDATE
                                   , L_CHANGETIME
                                   , D_FIRSTINVEST
                                   , C_PASSWORD
                                   , C_BOURSEFLAG
                                   , C_ACCOUNTCARDID
                                FROM ${hsfta_src_schema}.TACCOINFO"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_CUSTNO", "type": "STRING"}, {"name": "C_ACCOUNTTYPE", "type": "STRING"}, {"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "D_OPENDATE", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "C_ACCOSTATUS", "type": "STRING"}, {"name": "C_FREEZECAUSE", "type": "STRING"}, {"name": "D_BACKDATE", "type": "STRING"}, {"name": "L_CHANGETIME", "type": "DOUBLE"}, {"name": "D_FIRSTINVEST", "type": "STRING"}, {"name": "C_PASSWORD", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_ACCOUNTCARDID", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_taccoinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_taccoinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_taccoinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_taccoinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TACCOINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TACCOINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_taccoinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_CUSTNO
     , C_ACCOUNTTYPE
     , C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_CHILDNETNO
     , D_OPENDATE
     , D_LASTMODIFY
     , C_ACCOSTATUS
     , C_FREEZECAUSE
     , D_BACKDATE
     , L_CHANGETIME
     , D_FIRSTINVEST
     , C_PASSWORD
     , C_BOURSEFLAG
     , C_ACCOUNTCARDID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TACCOINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TACCOINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TACCOINFO_PFD成功"
      exit 0
   fi
fi
