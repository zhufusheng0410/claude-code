#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TGPSD_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGPSD_PFD_TMP(
  L_ZTBH  STRING  COMMENT  '帐套编号',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  D_SDBEGIN  STRING  COMMENT  '开始时间',
  D_SDEND  STRING  COMMENT  '结束时间',
  EN_SDJG  DECIMAL(19,4)  COMMENT  '锁定价格',
  L_XSLX  STRING  COMMENT  '限售类型',
  L_ID  DECIMAL(10,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '录入人',
  VC_FHR  STRING  COMMENT  '复核人',
  L_SDTS  DECIMAL(4,0)  COMMENT  ''
)
COMMENT '股票锁定表'
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_ZTBH
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , D_SDBEGIN
                                   , D_SDEND
                                   , EN_SDJG
                                   , L_XSLX
                                   , L_ID
                                   , VC_LLR
                                   , VC_FHR
                                   , L_SDTS
                                FROM ${hsfa_src_schema}.TGPSD"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "D_SDBEGIN", "type": "STRING"}, {"name": "D_SDEND", "type": "STRING"}, {"name": "EN_SDJG", "type": "DOUBLE"}, {"name": "L_XSLX", "type": "DOUBLE"}, {"name": "L_ID", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "L_SDTS", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tgpsd_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tgpsd_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tgpsd_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tgpsd_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TGPSD_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TGPSD_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tgpsd_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGPSD_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZTBH
     , L_ZQNM
     , VC_ZQDM
     , D_SDBEGIN
     , D_SDEND
     , EN_SDJG
     , L_XSLX
     , L_ID
     , VC_LLR
     , VC_FHR
     , L_SDTS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TGPSD_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGPSD_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TGPSD_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TGPSD_PFD成功"
      exit 0
   fi
fi
