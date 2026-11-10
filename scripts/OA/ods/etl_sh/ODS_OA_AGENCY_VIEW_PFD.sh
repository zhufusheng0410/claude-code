#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD_TMP;
CREATE TABLE ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD_TMP(
  BK_AGENCY  STRING  COMMENT  '渠道网点编码',
  AGENCY_PROVINCE_CODE  STRING  COMMENT  '网点省份代码',
  AGENCY_AREA_CODE  STRING  COMMENT  '网点城市代码',
  AGENCY_NETNO  STRING  COMMENT  '网点号',
  EFFECTIVE_FROM  DECIMAL(8,0)  COMMENT  '开始日期',
  EFFECTIVE_TO  DECIMAL(8,0)  COMMENT  '结束日期',
  DK_VIRTUAL_FLAG  STRING  COMMENT  '',
  SK_AGENCY  STRING  COMMENT  '网点编码',
  AGENCYNO  STRING  COMMENT  '渠道编号',
  AGENCY_NAME  STRING  COMMENT  '渠道名称',
  AGENCY_BRANCH_NAME  STRING  COMMENT  '网点名称',
  AGENCY_LEVEL  DECIMAL(4,0)  COMMENT  '网点级别',
  DK_SALE_CHANNEL  STRING  COMMENT  '',
  DK_AGENCY_TYPE  STRING  COMMENT  '渠道类型',
  BK_REGION  STRING  COMMENT  '区域编码',
  SK_AGENCY_PARENT  STRING  COMMENT  '上级区域编号'
)
COMMENT '网点视图'
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
            "username": "${oa_username}",
            "password": "${oa_password}",
            "connection": [{
              "querySql": ["SELECT  BK_AGENCY
                                   , AGENCY_PROVINCE_CODE
                                   , AGENCY_AREA_CODE
                                   , AGENCY_NETNO
                                   , EFFECTIVE_FROM
                                   , EFFECTIVE_TO
                                   , DK_VIRTUAL_FLAG
                                   , SK_AGENCY
                                   , AGENCYNO
                                   , AGENCY_NAME
                                   , AGENCY_BRANCH_NAME
                                   , AGENCY_LEVEL
                                   , DK_SALE_CHANNEL
                                   , DK_AGENCY_TYPE
                                   , BK_REGION
                                   , SK_AGENCY_PARENT
                                FROM ${oa_src_schema}.AGENCY_VIEW"],
              "jdbcUrl": ["${oa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "BK_AGENCY", "type": "STRING"}, {"name": "AGENCY_PROVINCE_CODE", "type": "STRING"}, {"name": "AGENCY_AREA_CODE", "type": "STRING"}, {"name": "AGENCY_NETNO", "type": "STRING"}, {"name": "EFFECTIVE_FROM", "type": "DOUBLE"}, {"name": "EFFECTIVE_TO", "type": "DOUBLE"}, {"name": "DK_VIRTUAL_FLAG", "type": "STRING"}, {"name": "SK_AGENCY", "type": "DOUBLE"}, {"name": "AGENCYNO", "type": "STRING"}, {"name": "AGENCY_NAME", "type": "STRING"}, {"name": "AGENCY_BRANCH_NAME", "type": "STRING"}, {"name": "AGENCY_LEVEL", "type": "DOUBLE"}, {"name": "DK_SALE_CHANNEL", "type": "STRING"}, {"name": "DK_AGENCY_TYPE", "type": "STRING"}, {"name": "BK_REGION", "type": "DOUBLE"}, {"name": "SK_AGENCY_PARENT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_oa_agency_view_pfd_tmp",
            "fileType": "text",
            "path": "${oa_path}/ods_oa_agency_view_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_oa_agency_view_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_oa_agency_view_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_OA_AGENCY_VIEW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_OA_AGENCY_VIEW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_oa_agency_view_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       BK_AGENCY
     , AGENCY_PROVINCE_CODE
     , AGENCY_AREA_CODE
     , AGENCY_NETNO
     , EFFECTIVE_FROM
     , EFFECTIVE_TO
     , DK_VIRTUAL_FLAG
     , SK_AGENCY
     , AGENCYNO
     , AGENCY_NAME
     , AGENCY_BRANCH_NAME
     , AGENCY_LEVEL
     , DK_SALE_CHANNEL
     , DK_AGENCY_TYPE
     , BK_REGION
     , SK_AGENCY_PARENT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_OA.ODS_OA_AGENCY_VIEW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_OA_AGENCY_VIEW_PFD失败"
      exit 1
   else
      echo "插入到ODS_OA_AGENCY_VIEW_PFD成功"
      exit 0
   fi
fi
