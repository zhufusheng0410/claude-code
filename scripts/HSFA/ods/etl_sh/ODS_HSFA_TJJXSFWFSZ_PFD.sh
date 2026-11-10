#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TJJXSFWFSZ_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJXSFWFSZ_PFD_TMP(
  L_ZTBH  STRING  COMMENT  '账套编号',
  VC_JJDM  STRING  COMMENT  '基金代码',
  VC_FJJJDM  STRING  COMMENT  '分级基金代码',
  VC_FJJJMC  STRING  COMMENT  '分级基金名称',
  EN_XSFL  DECIMAL(11,6)  COMMENT  '销售费率',
  D_BEGIN  STRING  COMMENT  '开始日期',
  D_END  STRING  COMMENT  '结束日期',
  L_MIN  DECIMAL(1,0)  COMMENT  '开启底限',
  EN_MIN  DECIMAL(19,4)  COMMENT  '底限',
  L_MAX  DECIMAL(1,0)  COMMENT  '开启上限',
  EN_MAX  DECIMAL(19,4)  COMMENT  '上限',
  L_JTFS  DECIMAL(2,0)  COMMENT  '',
  L_BLMS  DECIMAL(2,0)  COMMENT  '',
  L_TS  DECIMAL(4,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  ''
)
COMMENT '基金销售服务费率表'
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
                                   , VC_JJDM
                                   , VC_FJJJDM
                                   , VC_FJJJMC
                                   , EN_XSFL
                                   , D_BEGIN
                                   , D_END
                                   , L_MIN
                                   , EN_MIN
                                   , L_MAX
                                   , EN_MAX
                                   , L_JTFS
                                   , L_BLMS
                                   , L_TS
                                   , VC_LLR
                                   , VC_FHR
                                FROM ${hsfa_src_schema}.TJJXSFWFSZ"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_JJDM", "type": "STRING"}, {"name": "VC_FJJJDM", "type": "STRING"}, {"name": "VC_FJJJMC", "type": "STRING"}, {"name": "EN_XSFL", "type": "DOUBLE"}, {"name": "D_BEGIN", "type": "STRING"}, {"name": "D_END", "type": "STRING"}, {"name": "L_MIN", "type": "DOUBLE"}, {"name": "EN_MIN", "type": "DOUBLE"}, {"name": "L_MAX", "type": "DOUBLE"}, {"name": "EN_MAX", "type": "DOUBLE"}, {"name": "L_JTFS", "type": "DOUBLE"}, {"name": "L_BLMS", "type": "DOUBLE"}, {"name": "L_TS", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tjjxsfwfsz_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tjjxsfwfsz_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tjjxsfwfsz_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tjjxsfwfsz_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TJJXSFWFSZ_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TJJXSFWFSZ_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tjjxsfwfsz_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJXSFWFSZ_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZTBH
     , VC_JJDM
     , VC_FJJJDM
     , VC_FJJJMC
     , EN_XSFL
     , D_BEGIN
     , D_END
     , L_MIN
     , EN_MIN
     , L_MAX
     , EN_MAX
     , L_JTFS
     , L_BLMS
     , L_TS
     , VC_LLR
     , VC_FHR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TJJXSFWFSZ_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJXSFWFSZ_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TJJXSFWFSZ_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TJJXSFWFSZ_PFD成功"
      exit 0
   fi
fi
