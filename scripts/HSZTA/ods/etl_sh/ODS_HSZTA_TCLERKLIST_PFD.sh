#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TCLERKLIST_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCLERKLIST_PFD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_CUSTNAME  STRING  COMMENT  '客户名称',
  C_IDENTITYTYPE  STRING  COMMENT  '证件类型',
  C_IDENTITYNO  STRING  COMMENT  '证件号码',
  C_IDCARD18LEN  STRING  COMMENT  '卡BIN',
  C_FLAG  STRING  COMMENT  '标志',
  C_MOBILENO  STRING  COMMENT  '手机号码',
  D_ENTRYDATE  STRING  COMMENT  '入职日期',
  D_DEPARTUREDATE  STRING  COMMENT  '离职日期',
  C_COMPANY  STRING  COMMENT  '单位名称',
  C_WORKTYPE  STRING  COMMENT  '岗位',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_FUNDCODELIST  STRING  COMMENT  '',
  L_LIMITDAYS  DECIMAL(10,0)  COMMENT  '',
  C_DEPARTMENT  STRING  COMMENT  '',
  C_DEPARTBELONG  STRING  COMMENT  '',
  C_RELATION  STRING  COMMENT  '',
  C_POSITION  STRING  COMMENT  '',
  C_MEMO  STRING  COMMENT  '',
  C_ISJIONLOCALCONTRL  STRING  COMMENT  '',
  D_MODIFYTIME  STRING  COMMENT  ''
)
COMMENT '基金公司员工列表'
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
                                   , C_CUSTNAME
                                   , C_IDENTITYTYPE
                                   , C_IDENTITYNO
                                   , C_IDCARD18LEN
                                   , C_FLAG
                                   , C_MOBILENO
                                   , D_ENTRYDATE
                                   , D_DEPARTUREDATE
                                   , C_COMPANY
                                   , C_WORKTYPE
                                   , C_CUSTTYPE
                                   , C_FUNDCODELIST
                                   , L_LIMITDAYS
                                   , C_DEPARTMENT
                                   , C_DEPARTBELONG
                                   , C_RELATION
                                   , C_POSITION
                                   , C_MEMO
                                   , C_ISJIONLOCALCONTRL
                                   , D_MODIFYTIME
                                FROM ${hszta_src_schema}.TCLERKLIST"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_CUSTNAME", "type": "STRING"}, {"name": "C_IDENTITYTYPE", "type": "STRING"}, {"name": "C_IDENTITYNO", "type": "STRING"}, {"name": "C_IDCARD18LEN", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "C_MOBILENO", "type": "STRING"}, {"name": "D_ENTRYDATE", "type": "STRING"}, {"name": "D_DEPARTUREDATE", "type": "STRING"}, {"name": "C_COMPANY", "type": "STRING"}, {"name": "C_WORKTYPE", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_FUNDCODELIST", "type": "STRING"}, {"name": "L_LIMITDAYS", "type": "DOUBLE"}, {"name": "C_DEPARTMENT", "type": "STRING"}, {"name": "C_DEPARTBELONG", "type": "STRING"}, {"name": "C_RELATION", "type": "STRING"}, {"name": "C_POSITION", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_ISJIONLOCALCONTRL", "type": "STRING"}, {"name": "D_MODIFYTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tclerklist_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tclerklist_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tclerklist_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tclerklist_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TCLERKLIST_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TCLERKLIST_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tclerklist_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCLERKLIST_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDACCO
     , C_CUSTNAME
     , C_IDENTITYTYPE
     , C_IDENTITYNO
     , C_IDCARD18LEN
     , C_FLAG
     , C_MOBILENO
     , D_ENTRYDATE
     , D_DEPARTUREDATE
     , C_COMPANY
     , C_WORKTYPE
     , C_CUSTTYPE
     , C_FUNDCODELIST
     , L_LIMITDAYS
     , C_DEPARTMENT
     , C_DEPARTBELONG
     , C_RELATION
     , C_POSITION
     , C_MEMO
     , C_ISJIONLOCALCONTRL
     , D_MODIFYTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TCLERKLIST_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TCLERKLIST_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TCLERKLIST_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TCLERKLIST_PFD成功"
      exit 0
   fi
fi
