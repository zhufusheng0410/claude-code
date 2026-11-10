#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_OA.ODS_OA_COMM_REGION_HIERARCHY_PFD_TMP;
CREATE TABLE ODS_XDAY_OA.ODS_OA_COMM_REGION_HIERARCHY_PFD_TMP(
  SK_REGION  STRING  COMMENT  '区域编码',
  DK_REGION_TREE  STRING  COMMENT  '区域类型',
  REGION_LEVEL  DECIMAL(4,0)  COMMENT  '区域级别',
  SK_REGION_PARENT  STRING  COMMENT  '上级区域编码',
  EFFECTIVE_FROM  DECIMAL(8,0)  COMMENT  '开始日期',
  EFFECTIVE_TO  DECIMAL(8,0)  COMMENT  '结束日期',
  SK_REGION_OF_LV1  STRING  COMMENT  '一级区域编码',
  SK_REGION_OF_LV2  STRING  COMMENT  '二级区域编码',
  SK_REGION_OF_LV3  STRING  COMMENT  '三级区域编码',
  SK_REGION_OF_LV4  STRING  COMMENT  '四级区域编码',
  SK_REGION_OF_LV5  STRING  COMMENT  '五级区域编码',
  LVAL  DECIMAL(12,0)  COMMENT  '',
  RVAL  DECIMAL(12,0)  COMMENT  '',
  FLAG  STRING  COMMENT  '标志',
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
COMMENT '区域层级信息'
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
                                   , DK_REGION_TREE
                                   , REGION_LEVEL
                                   , SK_REGION_PARENT
                                   , EFFECTIVE_FROM
                                   , EFFECTIVE_TO
                                   , SK_REGION_OF_LV1
                                   , SK_REGION_OF_LV2
                                   , SK_REGION_OF_LV3
                                   , SK_REGION_OF_LV4
                                   , SK_REGION_OF_LV5
                                   , LVAL
                                   , RVAL
                                   , FLAG
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
                                FROM ${oa_src_schema}.COMM_REGION_HIERARCHY"],
              "jdbcUrl": ["${oa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "SK_REGION", "type": "DOUBLE"}, {"name": "DK_REGION_TREE", "type": "STRING"}, {"name": "REGION_LEVEL", "type": "DOUBLE"}, {"name": "SK_REGION_PARENT", "type": "DOUBLE"}, {"name": "EFFECTIVE_FROM", "type": "DOUBLE"}, {"name": "EFFECTIVE_TO", "type": "DOUBLE"}, {"name": "SK_REGION_OF_LV1", "type": "DOUBLE"}, {"name": "SK_REGION_OF_LV2", "type": "DOUBLE"}, {"name": "SK_REGION_OF_LV3", "type": "DOUBLE"}, {"name": "SK_REGION_OF_LV4", "type": "DOUBLE"}, {"name": "SK_REGION_OF_LV5", "type": "DOUBLE"}, {"name": "LVAL", "type": "DOUBLE"}, {"name": "RVAL", "type": "DOUBLE"}, {"name": "FLAG", "type": "DOUBLE"}, {"name": "MEMO", "type": "STRING"}, {"name": "SK_INVPTY_OF_CRT", "type": "DOUBLE"}, {"name": "SK_INVPTY_OF_MODI", "type": "DOUBLE"}, {"name": "DAC", "type": "DOUBLE"}, {"name": "DDVC", "type": "STRING"}, {"name": "DK_SYSTEM_OF_UPD", "type": "STRING"}, {"name": "BATCHNO", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "UUID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_oa_comm_region_hierarchy_pfd_tmp",
            "fileType": "text",
            "path": "${oa_path}/ods_oa_comm_region_hierarchy_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_oa_comm_region_hierarchy_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_oa_comm_region_hierarchy_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_OA_COMM_REGION_HIERARCHY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_OA_COMM_REGION_HIERARCHY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_oa_comm_region_hierarchy_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_OA.ODS_OA_COMM_REGION_HIERARCHY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       SK_REGION
     , DK_REGION_TREE
     , REGION_LEVEL
     , SK_REGION_PARENT
     , EFFECTIVE_FROM
     , EFFECTIVE_TO
     , SK_REGION_OF_LV1
     , SK_REGION_OF_LV2
     , SK_REGION_OF_LV3
     , SK_REGION_OF_LV4
     , SK_REGION_OF_LV5
     , LVAL
     , RVAL
     , FLAG
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
  FROM ODS_XDAY_OA.ODS_OA_COMM_REGION_HIERARCHY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_OA.ODS_OA_COMM_REGION_HIERARCHY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_OA_COMM_REGION_HIERARCHY_PFD失败"
      exit 1
   else
      echo "插入到ODS_OA_COMM_REGION_HIERARCHY_PFD成功"
      exit 0
   fi
fi
