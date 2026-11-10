#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD_TMP;
CREATE TABLE ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD_TMP(
  SK_REGION  STRING  COMMENT  '区域编码',
  BK_REGION  STRING  COMMENT  '区域代码',
  SK_COUNTRY  DECIMAL(12,0)  COMMENT  '',
  REGION_NAME  STRING  COMMENT  '区域名称',
  REGION_SHORT_NAME  STRING  COMMENT  '区域简称',
  ZIPCODE  STRING  COMMENT  '邮编',
  PHONE_AREA_CODE  STRING  COMMENT  '手机区域代码',
  DK_SPEC_FLAG  STRING  COMMENT  '',
  MEMO  STRING  COMMENT  '备注',
  SK_INVPTY_OF_CRT  DECIMAL(12,0)  COMMENT  '',
  SK_INVPTY_OF_MODI  DECIMAL(12,0)  COMMENT  '',
  DAC  DECIMAL(30,0)  COMMENT  '',
  DDVC  STRING  COMMENT  '',
  DK_SYSTEM_OF_UPD  STRING  COMMENT  '记录更新系统',
  BATCHNO  DECIMAL(16,0)  COMMENT  '批次号',
  INSERTTIME  STRING  COMMENT  '插入时间',
  UPDATETIME  STRING  COMMENT  '修改时间',
  UUID  DECIMAL(15,0)  COMMENT  '唯一ID'
)
COMMENT '区域信息'
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
              "querySql": ["SELECT  SK_REGION
                                   , BK_REGION
                                   , SK_COUNTRY
                                   , REGION_NAME
                                   , REGION_SHORT_NAME
                                   , ZIPCODE
                                   , PHONE_AREA_CODE
                                   , DK_SPEC_FLAG
                                   , MEMO
                                   , SK_INVPTY_OF_CRT
                                   , SK_INVPTY_OF_MODI
                                   , DAC
                                   , DDVC
                                   , DK_SYSTEM_OF_UPD
                                   , BATCHNO
                                   , INSERTTIME
                                   , UPDATETIME
                                   , UUID
                                FROM ${oa_src_schema}.COMM_REGION"],
              "jdbcUrl": ["${oa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "SK_REGION", "type": "DOUBLE"}, {"name": "BK_REGION", "type": "STRING"}, {"name": "SK_COUNTRY", "type": "DOUBLE"}, {"name": "REGION_NAME", "type": "STRING"}, {"name": "REGION_SHORT_NAME", "type": "STRING"}, {"name": "ZIPCODE", "type": "STRING"}, {"name": "PHONE_AREA_CODE", "type": "STRING"}, {"name": "DK_SPEC_FLAG", "type": "STRING"}, {"name": "MEMO", "type": "STRING"}, {"name": "SK_INVPTY_OF_CRT", "type": "DOUBLE"}, {"name": "SK_INVPTY_OF_MODI", "type": "DOUBLE"}, {"name": "DAC", "type": "DOUBLE"}, {"name": "DDVC", "type": "STRING"}, {"name": "DK_SYSTEM_OF_UPD", "type": "STRING"}, {"name": "BATCHNO", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "UUID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_oa_comm_region_pfd_tmp",
            "fileType": "text",
            "path": "${oa_path}/ods_oa_comm_region_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_oa_comm_region_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_oa_comm_region_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_OA_COMM_REGION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_OA_COMM_REGION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_oa_comm_region_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       SK_REGION
     , BK_REGION
     , SK_COUNTRY
     , REGION_NAME
     , REGION_SHORT_NAME
     , ZIPCODE
     , PHONE_AREA_CODE
     , DK_SPEC_FLAG
     , MEMO
     , SK_INVPTY_OF_CRT
     , SK_INVPTY_OF_MODI
     , DAC
     , DDVC
     , DK_SYSTEM_OF_UPD
     , BATCHNO
     , INSERTTIME
     , UPDATETIME
     , UUID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_OA.ODS_OA_COMM_REGION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_OA_COMM_REGION_PFD失败"
      exit 1
   else
      echo "插入到ODS_OA_COMM_REGION_PFD成功"
      exit 0
   fi
fi
