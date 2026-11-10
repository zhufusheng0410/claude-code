#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CONBDCHANGEINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDCHANGEINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  BONDCODE  STRING  COMMENT  '债券代码',
  BONDABBR  STRING  COMMENT  '可转债券简称',
  STARTDATE  STRING  COMMENT  '起始日期',
  PUTLEVEL  DECIMAL(19,8)  COMMENT  '修正触发转股价比例',
  PUTCHANGEPRO  DECIMAL(19,8)  COMMENT  '修正幅度',
  PUTSTARTDATE  STRING  COMMENT  '修正开始日期',
  PUTENDDATE  STRING  COMMENT  '修正结束日期',
  PUTTYPE  DECIMAL(3,0)  COMMENT  '行使权力次数',
  PUTTYPENAME  STRING  COMMENT  '行使权力次数名称',
  PUTCONDITIONDAY  DECIMAL(10,0)  COMMENT  '修正条件天数',
  PUTREACHDAY  DECIMAL(10,0)  COMMENT  '修正条件满足天数',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  ADJDIRECTION  DECIMAL(10,0)  COMMENT  '',
  ADJMODE  DECIMAL(10,0)  COMMENT  '',
  MULTILEVEL  DECIMAL(10,0)  COMMENT  '多个触发比例筛选',
  MULTIADJMODE  DECIMAL(10,0)  COMMENT  '多个修正方式筛选'
)
COMMENT '可转债券修正信息'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , BONDCODE
                                   , BONDABBR
                                   , STARTDATE
                                   , PUTLEVEL
                                   , PUTCHANGEPRO
                                   , PUTSTARTDATE
                                   , PUTENDDATE
                                   , PUTTYPE
                                   , PUTTYPENAME
                                   , PUTCONDITIONDAY
                                   , PUTREACHDAY
                                   , UPDATETIME
                                   , JSID
                                   , ADJDIRECTION
                                   , ADJMODE
                                   , MULTILEVEL
                                   , MULTIADJMODE
                                FROM ${jy_src_schema}.BOND_CONBDCHANGEINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "BONDCODE", "type": "STRING"}, {"name": "BONDABBR", "type": "STRING"}, {"name": "STARTDATE", "type": "STRING"}, {"name": "PUTLEVEL", "type": "DOUBLE"}, {"name": "PUTCHANGEPRO", "type": "DOUBLE"}, {"name": "PUTSTARTDATE", "type": "STRING"}, {"name": "PUTENDDATE", "type": "STRING"}, {"name": "PUTTYPE", "type": "DOUBLE"}, {"name": "PUTTYPENAME", "type": "STRING"}, {"name": "PUTCONDITIONDAY", "type": "DOUBLE"}, {"name": "PUTREACHDAY", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "ADJDIRECTION", "type": "DOUBLE"}, {"name": "ADJMODE", "type": "DOUBLE"}, {"name": "MULTILEVEL", "type": "DOUBLE"}, {"name": "MULTIADJMODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_conbdchangeinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_conbdchangeinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_conbdchangeinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_conbdchangeinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CONBDCHANGEINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CONBDCHANGEINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_conbdchangeinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDCHANGEINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , BONDCODE
     , BONDABBR
     , STARTDATE
     , PUTLEVEL
     , PUTCHANGEPRO
     , PUTSTARTDATE
     , PUTENDDATE
     , PUTTYPE
     , PUTTYPENAME
     , PUTCONDITIONDAY
     , PUTREACHDAY
     , UPDATETIME
     , JSID
     , ADJDIRECTION
     , ADJMODE
     , MULTILEVEL
     , MULTIADJMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CONBDCHANGEINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDCHANGEINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CONBDCHANGEINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CONBDCHANGEINFO_PFD成功"
      exit 0
   fi
fi
