#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TEXCHRATE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TEXCHRATE_PFD_TMP(
  L_ID  STRING  COMMENT  '唯一编号',
  L_EXCHID  STRING  COMMENT  '【放弃使用】币种编号',
  L_PERIOD  DECIMAL(2,0)  COMMENT  '【放弃使用】会计期间',
  L_TYPE  STRING  COMMENT  '【放弃使用】汇率类型',
  D_EXCH  STRING  COMMENT  '汇率执行日期',
  EN_RATE  DECIMAL(20,14)  COMMENT  '汇率',
  L_FUNDID  STRING  COMMENT  '【放弃使用】账套编号',
  VC_YBBM  STRING  COMMENT  '原币编码',
  VC_BBBM  STRING  COMMENT  '本币编码',
  EN_WBBZ  DECIMAL(8,4)  COMMENT  '外币标准',
  D_SCSJ  STRING  COMMENT  '生成时间',
  C_SJLY  STRING  COMMENT  '数据来源',
  VC_BZ  STRING  COMMENT  '备注',
  C_SYNCHRO_FLAG  STRING  COMMENT  '同步标志',
  D_SYNCHRO_TIME  STRING  COMMENT  '同步时间',
  L_CLBZ  DECIMAL(1,0)  COMMENT  '',
  L_MAKER  DECIMAL(4,0)  COMMENT  '',
  L_CHECKER  DECIMAL(4,0)  COMMENT  ''
)
COMMENT '汇率表'
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
              "querySql": ["SELECT  L_ID
                                   , L_EXCHID
                                   , L_PERIOD
                                   , L_TYPE
                                   , TO_CHAR(D_EXCH,'YYYYMMDD') D_EXCH
                                   , EN_RATE
                                   , L_FUNDID
                                   , VC_YBBM
                                   , VC_BBBM
                                   , EN_WBBZ
                                   , D_SCSJ
                                   , C_SJLY
                                   , VC_BZ
                                   , C_SYNCHRO_FLAG
                                   , D_SYNCHRO_TIME
                                   , L_CLBZ
                                   , L_MAKER
                                   , L_CHECKER
                                FROM ${hsfa_src_schema}.TEXCHRATE"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "L_EXCHID", "type": "DOUBLE"}, {"name": "L_PERIOD", "type": "DOUBLE"}, {"name": "L_TYPE", "type": "DOUBLE"}, {"name": "D_EXCH", "type": "STRING"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "L_FUNDID", "type": "DOUBLE"}, {"name": "VC_YBBM", "type": "STRING"}, {"name": "VC_BBBM", "type": "STRING"}, {"name": "EN_WBBZ", "type": "DOUBLE"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "C_SJLY", "type": "STRING"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "C_SYNCHRO_FLAG", "type": "STRING"}, {"name": "D_SYNCHRO_TIME", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "L_MAKER", "type": "DOUBLE"}, {"name": "L_CHECKER", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_texchrate_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_texchrate_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_texchrate_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_texchrate_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TEXCHRATE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TEXCHRATE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_texchrate_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TEXCHRATE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ID
     , L_EXCHID
     , L_PERIOD
     , L_TYPE
     , D_EXCH
     , EN_RATE
     , L_FUNDID
     , VC_YBBM
     , VC_BBBM
     , EN_WBBZ
     , D_SCSJ
     , C_SJLY
     , VC_BZ
     , C_SYNCHRO_FLAG
     , D_SYNCHRO_TIME
     , L_CLBZ
     , L_MAKER
     , L_CHECKER
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TEXCHRATE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TEXCHRATE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TEXCHRATE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TEXCHRATE_PFD成功"
      exit 0
   fi
fi
