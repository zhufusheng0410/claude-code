#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_AUDITOPINION_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_AUDITOPINION_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  ENDDATE  STRING  COMMENT  '日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  ACCOUNTINGFIRMS  STRING  COMMENT  '会计师事务所',
  INSTIBELONGEDCODE  DECIMAL(10,0)  COMMENT  '所属机构',
  CPA  STRING  COMMENT  '注册会计师',
  OPINIONTYPE  STRING  COMMENT  '审计意见类型',
  OPINIONFULLTEXT  STRING  COMMENT  '审计意见全文',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  AUDITREPORTSTYPE  STRING  COMMENT  '审计报告类型',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '公司历年审计意见'
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
                                   , ENDDATE
                                   , INFOSOURCE
                                   , ACCOUNTINGFIRMS
                                   , INSTIBELONGEDCODE
                                   , CPA
                                   , OPINIONTYPE
                                   , OPINIONFULLTEXT
                                   , XGRQ
                                   , JSID
                                   , INFOPUBLDATE
                                   , AUDITREPORTSTYPE
                                   , INSERTTIME
                                FROM ${jy_src_schema}.LC_AUDITOPINION"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "ACCOUNTINGFIRMS", "type": "STRING"}, {"name": "INSTIBELONGEDCODE", "type": "DOUBLE"}, {"name": "CPA", "type": "STRING"}, {"name": "OPINIONTYPE", "type": "DOUBLE"}, {"name": "OPINIONFULLTEXT", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "AUDITREPORTSTYPE", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_auditopinion_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_auditopinion_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_auditopinion_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_auditopinion_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_AUDITOPINION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_AUDITOPINION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_auditopinion_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_AUDITOPINION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , ENDDATE
     , INFOSOURCE
     , ACCOUNTINGFIRMS
     , INSTIBELONGEDCODE
     , CPA
     , OPINIONTYPE
     , OPINIONFULLTEXT
     , XGRQ
     , JSID
     , INFOPUBLDATE
     , AUDITREPORTSTYPE
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_AUDITOPINION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_AUDITOPINION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_AUDITOPINION_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_AUDITOPINION_PFD成功"
      exit 0
   fi
fi
