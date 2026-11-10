#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  REPORTDATE  STRING  COMMENT  '填报日期',
  SERIALNUMBER  DECIMAL(10,0)  COMMENT  '序号',
  FUNDINNERCODE  STRING  COMMENT  '投资基金内部编码',
  SHARESHOLDING  DECIMAL(18,4)  COMMENT  '持股数量(股)',
  MARKETVALUE  DECIMAL(18,4)  COMMENT  '总市值(元)',
  RATIOINNV  DECIMAL(18,6)  COMMENT  '占资产净值比例',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  DECIMAL(10,0)  COMMENT  '信息来源',
  IFMANAGERFUND  DECIMAL(10,0)  COMMENT  '是否管理人及关联方管理基金',
  INSERTTIME  STRING  COMMENT  '插入时间',
  TRANSCODE  STRING  COMMENT  '基金转型统一编码'
)
COMMENT '公募基金投资基金明细'
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
                                   , REPORTDATE
                                   , SERIALNUMBER
                                   , FUNDINNERCODE
                                   , SHARESHOLDING
                                   , MARKETVALUE
                                   , RATIOINNV
                                   , UPDATETIME
                                   , JSID
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , IFMANAGERFUND
                                   , INSERTTIME
                                   , TRANSCODE
                                FROM ${jy_src_schema}.MF_FUNDPORTIFOLIODETAIL"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "REPORTDATE", "type": "STRING"}, {"name": "SERIALNUMBER", "type": "DOUBLE"}, {"name": "FUNDINNERCODE", "type": "DOUBLE"}, {"name": "SHARESHOLDING", "type": "DOUBLE"}, {"name": "MARKETVALUE", "type": "DOUBLE"}, {"name": "RATIOINNV", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "DOUBLE"}, {"name": "IFMANAGERFUND", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_fundportifoliodetail_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_fundportifoliodetail_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_fundportifoliodetail_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_fundportifoliodetail_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_fundportifoliodetail_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , REPORTDATE
     , SERIALNUMBER
     , FUNDINNERCODE
     , SHARESHOLDING
     , MARKETVALUE
     , RATIOINNV
     , UPDATETIME
     , JSID
     , INFOPUBLDATE
     , INFOSOURCE
     , IFMANAGERFUND
     , INSERTTIME
     , TRANSCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_FUNDPORTIFOLIODETAIL_PFD成功"
      exit 0
   fi
fi
