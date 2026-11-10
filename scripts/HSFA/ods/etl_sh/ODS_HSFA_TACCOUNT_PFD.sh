#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD_TMP(
  VC_CODE  STRING  COMMENT  '会计科目编码',
  L_FUNDID  DECIMAL(9,0)  COMMENT  '对应账套',
  VC_NAME  STRING  COMMENT  '会计科目名称',
  L_LEVEL  DECIMAL(2,0)  COMMENT  '所属级次',
  VC_PARENT  STRING  COMMENT  '上级会计科目编码',
  L_KIND  DECIMAL(2,1)  COMMENT  '科目方向',
  L_CLASS  STRING  COMMENT  '会计科目分类',
  L_QUANTITY  DECIMAL(4,0)  COMMENT  '数量核算',
  D_CREATE  STRING  COMMENT  '创建日期',
  L_VOID  DECIMAL(1,0)  COMMENT  '废除标记',
  L_LEAF  DECIMAL(1,0)  COMMENT  '叶子节点标记',
  VC_CODE_HS  STRING  COMMENT  '恒生标准会计科目',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  VC_FZHS  STRING  COMMENT  '辅助核算标志位',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别'
)
COMMENT '会计科目表'
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
              "querySql": ["SELECT  VC_CODE
                                   , L_FUNDID
                                   , VC_NAME
                                   , L_LEVEL
                                   , VC_PARENT
                                   , L_KIND
                                   , L_CLASS
                                   , L_QUANTITY
                                   , D_CREATE
                                   , L_VOID
                                   , L_LEAF
                                   , VC_CODE_HS
                                   , VC_JSBZ
                                   , VC_FZHS
                                   , L_SCLB
                                FROM ${hsfa_src_schema}.TACCOUNT"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_CODE", "type": "STRING"}, {"name": "L_FUNDID", "type": "DOUBLE"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "L_LEVEL", "type": "DOUBLE"}, {"name": "VC_PARENT", "type": "STRING"}, {"name": "L_KIND", "type": "DOUBLE"}, {"name": "L_CLASS", "type": "DOUBLE"}, {"name": "L_QUANTITY", "type": "DOUBLE"}, {"name": "D_CREATE", "type": "STRING"}, {"name": "L_VOID", "type": "DOUBLE"}, {"name": "L_LEAF", "type": "DOUBLE"}, {"name": "VC_CODE_HS", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "VC_FZHS", "type": "STRING"}, {"name": "L_SCLB", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_taccount_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_taccount_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_taccount_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_taccount_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TACCOUNT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TACCOUNT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_taccount_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_CODE
     , L_FUNDID
     , VC_NAME
     , L_LEVEL
     , VC_PARENT
     , L_KIND
     , L_CLASS
     , L_QUANTITY
     , D_CREATE
     , L_VOID
     , L_LEAF
     , VC_CODE_HS
     , VC_JSBZ
     , VC_FZHS
     , L_SCLB
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TACCOUNT_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TACCOUNT_PFD成功"
      exit 0
   fi
fi
