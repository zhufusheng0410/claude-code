#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTRIKEBUSINESS_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTRIKEBUSINESS_PFD_TMP(
  L_BUSIN_NO  DECIMAL(10,0)  COMMENT  '业务序号',
  L_BATCH_NO  DECIMAL(10,0)  COMMENT  '批号',
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '发生时间',
  VC_BUSIN_OPFLAG  STRING  COMMENT  '业务操作类型',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_RATIO  DECIMAL(16,8)  COMMENT  '分配比例',
  EN_PRICE  DECIMAL(16,8)  COMMENT  '价格',
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  VC_MEMO  STRING  COMMENT  '备注',
  L_CHECK_DATE  DECIMAL(8,0)  COMMENT  '复核日期',
  L_CHECK_TIME  DECIMAL(6,0)  COMMENT  '复核时间',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核员',
  C_CHECK_FLAG  STRING  COMMENT  '复核标志',
  VC_CHECK_MEMO  STRING  COMMENT  '复核备注',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  D_DATETIME  STRING  COMMENT  '时间戳',
  L_REGISTER_DATE  DECIMAL(8,0)  COMMENT  '权益日期'
)
COMMENT '结算类业务表'
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
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  L_BUSIN_NO
                                   , L_BATCH_NO
                                   , L_DATE
                                   , L_TIME
                                   , VC_BUSIN_OPFLAG
                                   , VC_INTER_CODE
                                   , EN_RATIO
                                   , EN_PRICE
                                   , L_OPERATOR_NO
                                   , VC_MEMO
                                   , L_CHECK_DATE
                                   , L_CHECK_TIME
                                   , L_CHECK_OPERATOR
                                   , C_CHECK_FLAG
                                   , VC_CHECK_MEMO
                                   , C_DEAL_FLAG
                                   , D_DATETIME
                                   , L_REGISTER_DATE
                                FROM ${o32_src_schema}.TSTRIKEBUSINESS"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BUSIN_NO", "type": "DOUBLE"}, {"name": "L_BATCH_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_BUSIN_OPFLAG", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_RATIO", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "L_CHECK_DATE", "type": "DOUBLE"}, {"name": "L_CHECK_TIME", "type": "DOUBLE"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "C_CHECK_FLAG", "type": "STRING"}, {"name": "VC_CHECK_MEMO", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "L_REGISTER_DATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstrikebusiness_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstrikebusiness_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstrikebusiness_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstrikebusiness_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTRIKEBUSINESS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTRIKEBUSINESS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstrikebusiness_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTRIKEBUSINESS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BUSIN_NO
     , L_BATCH_NO
     , L_DATE
     , L_TIME
     , VC_BUSIN_OPFLAG
     , VC_INTER_CODE
     , EN_RATIO
     , EN_PRICE
     , L_OPERATOR_NO
     , VC_MEMO
     , L_CHECK_DATE
     , L_CHECK_TIME
     , L_CHECK_OPERATOR
     , C_CHECK_FLAG
     , VC_CHECK_MEMO
     , C_DEAL_FLAG
     , D_DATETIME
     , L_REGISTER_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSTRIKEBUSINESS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTRIKEBUSINESS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTRIKEBUSINESS_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTRIKEBUSINESS_PFD成功"
      exit 0
   fi
fi
