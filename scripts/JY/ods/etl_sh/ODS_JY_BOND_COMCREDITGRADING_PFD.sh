#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_COMCREDITGRADING_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_COMCREDITGRADING_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  COMPANYNAME  STRING  COMMENT  '公司名称',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  CRDATE  STRING  COMMENT  '评级日期',
  CRASCODE  STRING  COMMENT  '评级机构代码',
  CRASNAME  STRING  COMMENT  '评级机构名称',
  CRCODE  STRING  COMMENT  '信用级别代码',
  CRDESC  STRING  COMMENT  '信用级别描述',
  CRSYSTEM  DECIMAL(10,0)  COMMENT  '评级体系',
  CRANTICIPATE  STRING  COMMENT  '评级展望',
  CRSTATUS  DECIMAL(10,0)  COMMENT  '评级状态',
  CHANGERESON  STRING  COMMENT  '评级状态变更说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  CRTYPE  STRING  COMMENT  '评级类型',
  CROUTLOOK  DECIMAL(10,0)  COMMENT  '债券展望',
  CRWISH  DECIMAL(10,0)  COMMENT  '评级意愿',
  LASTCRDATE  STRING  COMMENT  '上期评级日期',
  LASTCRDESC  STRING  COMMENT  '上期评级描述1',
  LASTCRCODE  DECIMAL(10,0)  COMMENT  '上期评级级别',
  INFOSOURCETYPE  STRING  COMMENT  '公告来源类型'
)
COMMENT '债券相关机构信用评级'
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
                                   , COMPANYCODE
                                   , COMPANYNAME
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , CRDATE
                                   , CRASCODE
                                   , CRASNAME
                                   , CRCODE
                                   , CRDESC
                                   , CRSYSTEM
                                   , CRANTICIPATE
                                   , CRSTATUS
                                   , CHANGERESON
                                   , UPDATETIME
                                   , JSID
                                   , CRTYPE
                                   , CROUTLOOK
                                   , CRWISH
                                   , LASTCRDATE
                                   , LASTCRDESC
                                   , LASTCRCODE
                                   , INFOSOURCETYPE
                                FROM ${jy_src_schema}.BOND_COMCREDITGRADING"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "COMPANYNAME", "type": "STRING"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "CRDATE", "type": "STRING"}, {"name": "CRASCODE", "type": "DOUBLE"}, {"name": "CRASNAME", "type": "STRING"}, {"name": "CRCODE", "type": "DOUBLE"}, {"name": "CRDESC", "type": "STRING"}, {"name": "CRSYSTEM", "type": "DOUBLE"}, {"name": "CRANTICIPATE", "type": "STRING"}, {"name": "CRSTATUS", "type": "DOUBLE"}, {"name": "CHANGERESON", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "CRTYPE", "type": "DOUBLE"}, {"name": "CROUTLOOK", "type": "DOUBLE"}, {"name": "CRWISH", "type": "DOUBLE"}, {"name": "LASTCRDATE", "type": "STRING"}, {"name": "LASTCRDESC", "type": "STRING"}, {"name": "LASTCRCODE", "type": "DOUBLE"}, {"name": "INFOSOURCETYPE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_comcreditgrading_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_comcreditgrading_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_comcreditgrading_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_comcreditgrading_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_COMCREDITGRADING_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_COMCREDITGRADING_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_comcreditgrading_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_COMCREDITGRADING_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , COMPANYNAME
     , INFOPUBLDATE
     , INFOSOURCE
     , CRDATE
     , CRASCODE
     , CRASNAME
     , CRCODE
     , CRDESC
     , CRSYSTEM
     , CRANTICIPATE
     , CRSTATUS
     , CHANGERESON
     , UPDATETIME
     , JSID
     , CRTYPE
     , CROUTLOOK
     , CRWISH
     , LASTCRDATE
     , LASTCRDESC
     , LASTCRCODE
     , INFOSOURCETYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_COMCREDITGRADING_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_COMCREDITGRADING_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_COMCREDITGRADING_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_COMCREDITGRADING_PFD成功"
      exit 0
   fi
fi
