#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_EXGINDUSTRY_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_EXGINDUSTRY_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  STANDARD  DECIMAL(10,0)  COMMENT  '行业划分标准',
  INDUSTRY  DECIMAL(10,0)  COMMENT  '所属行业',
  IFPERFORMED  DECIMAL(10,0)  COMMENT  '是否执行',
  CANCELDATE  STRING  COMMENT  '取消日期',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  FIRSTINDUSTRYCODE  STRING  COMMENT  '对应一级行业代码',
  FIRSTINDUSTRYNAME  STRING  COMMENT  '对应一级行业名称',
  SECONDINDUSTRYCODE  STRING  COMMENT  '对应二级行业代码',
  SECONDINDUSTRYNAME  STRING  COMMENT  '对应二级行业名称',
  THIRDINDUSTRYCODE  STRING  COMMENT  '对应三级行业代码',
  THIRDINDUSTRYNAME  STRING  COMMENT  '对应三级行业名称',
  FOURTHINDUSTRYCODE  STRING  COMMENT  '四级行业代码',
  FOURTHINDUSTRYNAME  STRING  COMMENT  '四级行业名称',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '公司行业划分表'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , STANDARD
                                   , INDUSTRY
                                   , IFPERFORMED
                                   , CANCELDATE
                                   , XGRQ
                                   , JSID
                                   , FIRSTINDUSTRYCODE
                                   , FIRSTINDUSTRYNAME
                                   , SECONDINDUSTRYCODE
                                   , SECONDINDUSTRYNAME
                                   , THIRDINDUSTRYCODE
                                   , THIRDINDUSTRYNAME
                                   , FOURTHINDUSTRYCODE
                                   , FOURTHINDUSTRYNAME
                                   , INSERTTIME
                                FROM ${jy_src_schema}.LC_EXGINDUSTRY"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "STANDARD", "type": "DOUBLE"}, {"name": "INDUSTRY", "type": "DOUBLE"}, {"name": "IFPERFORMED", "type": "DOUBLE"}, {"name": "CANCELDATE", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "FIRSTINDUSTRYCODE", "type": "STRING"}, {"name": "FIRSTINDUSTRYNAME", "type": "STRING"}, {"name": "SECONDINDUSTRYCODE", "type": "STRING"}, {"name": "SECONDINDUSTRYNAME", "type": "STRING"}, {"name": "THIRDINDUSTRYCODE", "type": "STRING"}, {"name": "THIRDINDUSTRYNAME", "type": "STRING"}, {"name": "FOURTHINDUSTRYCODE", "type": "STRING"}, {"name": "FOURTHINDUSTRYNAME", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_exgindustry_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_exgindustry_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_exgindustry_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_exgindustry_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_EXGINDUSTRY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_EXGINDUSTRY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_exgindustry_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_EXGINDUSTRY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , STANDARD
     , INDUSTRY
     , IFPERFORMED
     , CANCELDATE
     , XGRQ
     , JSID
     , FIRSTINDUSTRYCODE
     , FIRSTINDUSTRYNAME
     , SECONDINDUSTRYCODE
     , SECONDINDUSTRYNAME
     , THIRDINDUSTRYCODE
     , THIRDINDUSTRYNAME
     , FOURTHINDUSTRYCODE
     , FOURTHINDUSTRYNAME
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_EXGINDUSTRY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_EXGINDUSTRY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_EXGINDUSTRY_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_EXGINDUSTRY_PFD成功"
      exit 0
   fi
fi
