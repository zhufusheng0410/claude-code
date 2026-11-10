#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_INSTIQUALCORE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_INSTIQUALCORE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  DECIMAL(10,0)  COMMENT  '信息来源',
  COMPANYCODE  STRING  COMMENT  '机构编码',
  AGENTNAME  STRING  COMMENT  '机构名称',
  QUALCATEGORY  DECIMAL(10,0)  COMMENT  '资格类别1',
  QUALCODE  STRING  COMMENT  '资格内部编码',
  QUALNAME  STRING  COMMENT  '资格名称',
  ADMINNUMBER  STRING  COMMENT  '行政文号',
  QUALSTARTDATE  STRING  COMMENT  '资格起始日',
  QUALENDDATE  STRING  COMMENT  '资格截止日',
  QUALSTATE  DECIMAL(10,0)  COMMENT  '资格状态',
  REMARK  STRING  COMMENT  '备注',
  INSERTTIME  STRING  COMMENT  '发布时间',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '机构资格对应关系表'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , COMPANYCODE
                                   , AGENTNAME
                                   , QUALCATEGORY
                                   , QUALCODE
                                   , QUALNAME
                                   , ADMINNUMBER
                                   , QUALSTARTDATE
                                   , QUALENDDATE
                                   , QUALSTATE
                                   , REMARK
                                   , INSERTTIME
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.LC_INSTIQUALCORE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "AGENTNAME", "type": "STRING"}, {"name": "QUALCATEGORY", "type": "DOUBLE"}, {"name": "QUALCODE", "type": "DOUBLE"}, {"name": "QUALNAME", "type": "STRING"}, {"name": "ADMINNUMBER", "type": "STRING"}, {"name": "QUALSTARTDATE", "type": "STRING"}, {"name": "QUALENDDATE", "type": "STRING"}, {"name": "QUALSTATE", "type": "DOUBLE"}, {"name": "REMARK", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_instiqualcore_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_instiqualcore_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_instiqualcore_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_instiqualcore_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_INSTIQUALCORE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_INSTIQUALCORE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_instiqualcore_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_INSTIQUALCORE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INFOPUBLDATE
     , INFOSOURCE
     , COMPANYCODE
     , AGENTNAME
     , QUALCATEGORY
     , QUALCODE
     , QUALNAME
     , ADMINNUMBER
     , QUALSTARTDATE
     , QUALENDDATE
     , QUALSTATE
     , REMARK
     , INSERTTIME
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_INSTIQUALCORE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_INSTIQUALCORE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_INSTIQUALCORE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_INSTIQUALCORE_PFD成功"
      exit 0
   fi
fi
