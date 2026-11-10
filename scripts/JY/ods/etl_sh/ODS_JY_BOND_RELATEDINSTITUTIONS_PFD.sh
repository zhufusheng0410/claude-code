#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_RELATEDINSTITUTIONS_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_RELATEDINSTITUTIONS_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  BONDTYPE  DECIMAL(10,0)  COMMENT  '债券类别',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  AGENTTYPE  DECIMAL(10,0)  COMMENT  '机构类别',
  SN  DECIMAL(10,0)  COMMENT  '显示序号',
  FULLNAME  STRING  COMMENT  '机构全称',
  REPRESENTATIVE  STRING  COMMENT  '代表人',
  HANDLINGPERSON  STRING  COMMENT  '事件经办人',
  LEGALPERSONREPR  STRING  COMMENT  '法人代表',
  CONTACTADDR  STRING  COMMENT  '公司联系地址',
  POSTCODE  STRING  COMMENT  '邮编',
  WEBSITE  STRING  COMMENT  '公司网址',
  EMAIL  STRING  COMMENT  '邮箱',
  CONTACTMAN  STRING  COMMENT  '联系人',
  TEL  STRING  COMMENT  '电话',
  FAX  STRING  COMMENT  '传真',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  QUALCATEGORY  DECIMAL(10,0)  COMMENT  '承销团资格类别',
  INSERTTIME  STRING  COMMENT  '发布时间',
  ISSUETYPE  STRING  COMMENT  '发行类型'
)
COMMENT '债券相关机构基本信息表'
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
                                   , MAINCODE
                                   , BONDTYPE
                                   , INITIALINFOPUBLDATE
                                   , AGENTTYPE
                                   , SN
                                   , FULLNAME
                                   , REPRESENTATIVE
                                   , HANDLINGPERSON
                                   , LEGALPERSONREPR
                                   , CONTACTADDR
                                   , POSTCODE
                                   , WEBSITE
                                   , EMAIL
                                   , CONTACTMAN
                                   , TEL
                                   , FAX
                                   , UPDATETIME
                                   , JSID
                                   , COMPANYCODE
                                   , QUALCATEGORY
                                   , INSERTTIME
                                   , ISSUETYPE
                                FROM ${jy_src_schema}.BOND_RELATEDINSTITUTIONS"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "BONDTYPE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "AGENTTYPE", "type": "DOUBLE"}, {"name": "SN", "type": "DOUBLE"}, {"name": "FULLNAME", "type": "STRING"}, {"name": "REPRESENTATIVE", "type": "STRING"}, {"name": "HANDLINGPERSON", "type": "STRING"}, {"name": "LEGALPERSONREPR", "type": "STRING"}, {"name": "CONTACTADDR", "type": "STRING"}, {"name": "POSTCODE", "type": "STRING"}, {"name": "WEBSITE", "type": "STRING"}, {"name": "EMAIL", "type": "STRING"}, {"name": "CONTACTMAN", "type": "STRING"}, {"name": "TEL", "type": "STRING"}, {"name": "FAX", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "QUALCATEGORY", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "ISSUETYPE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_relatedinstitutions_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_relatedinstitutions_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_relatedinstitutions_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_relatedinstitutions_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_RELATEDINSTITUTIONS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_RELATEDINSTITUTIONS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_relatedinstitutions_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_RELATEDINSTITUTIONS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , BONDTYPE
     , INITIALINFOPUBLDATE
     , AGENTTYPE
     , SN
     , FULLNAME
     , REPRESENTATIVE
     , HANDLINGPERSON
     , LEGALPERSONREPR
     , CONTACTADDR
     , POSTCODE
     , WEBSITE
     , EMAIL
     , CONTACTMAN
     , TEL
     , FAX
     , UPDATETIME
     , JSID
     , COMPANYCODE
     , QUALCATEGORY
     , INSERTTIME
     , ISSUETYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_RELATEDINSTITUTIONS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_RELATEDINSTITUTIONS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_RELATEDINSTITUTIONS_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_RELATEDINSTITUTIONS_PFD成功"
      exit 0
   fi
fi
