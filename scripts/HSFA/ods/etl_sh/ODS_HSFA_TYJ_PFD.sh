#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TYJ_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYJ_PFD_TMP(
  L_BH  DECIMAL(10,0)  COMMENT  '',
  VC_QSBH  STRING  COMMENT  '券商编号',
  VC_WTFS  STRING  COMMENT  '',
  L_FYBH  STRING  COMMENT  '费用编号',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_FBHB  DECIMAL(1,0)  COMMENT  '分笔合笔',
  D_KSRQ  STRING  COMMENT  '开始日期',
  D_JSRQ  STRING  COMMENT  '结束日期',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  L_YWMXBH  STRING  COMMENT  '业务明细编号',
  VC_CRFS  STRING  COMMENT  '传入方式',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_GDDM  STRING  COMMENT  ''
)
COMMENT '佣金费率主表'
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
              "querySql": ["SELECT  L_BH
                                   , VC_QSBH
                                   , VC_WTFS
                                   , L_FYBH
                                   , L_SCLB
                                   , L_FBHB
                                   , D_KSRQ
                                   , D_JSRQ
                                   , L_YWLB
                                   , L_YWMXBH
                                   , VC_CRFS
                                   , L_ZTBH
                                   , VC_LLR
                                   , VC_FHR
                                   , VC_GDDM
                                FROM ${hsfa_src_schema}.TYJ"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "VC_WTFS", "type": "STRING"}, {"name": "L_FYBH", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_FBHB", "type": "DOUBLE"}, {"name": "D_KSRQ", "type": "STRING"}, {"name": "D_JSRQ", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_YWMXBH", "type": "DOUBLE"}, {"name": "VC_CRFS", "type": "STRING"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_GDDM", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tyj_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tyj_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tyj_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tyj_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TYJ_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TYJ_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tyj_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYJ_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BH
     , VC_QSBH
     , VC_WTFS
     , L_FYBH
     , L_SCLB
     , L_FBHB
     , D_KSRQ
     , D_JSRQ
     , L_YWLB
     , L_YWMXBH
     , VC_CRFS
     , L_ZTBH
     , VC_LLR
     , VC_FHR
     , VC_GDDM
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TYJ_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYJ_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TYJ_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TYJ_PFD成功"
      exit 0
   fi
fi
