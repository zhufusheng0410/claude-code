#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TQSKJZ_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSKJZ_PFD_TMP(
  L_BH  STRING  COMMENT  '编号',
  L_ZTBH  STRING  COMMENT  '帐套编号',
  VC_ZY  STRING  COMMENT  '摘要',
  VC_DYKM  STRING  COMMENT  '对应科目',
  VC_JFKM  STRING  COMMENT  '借方科目',
  VC_DFKM  STRING  COMMENT  '贷方科目',
  L_TS  DECIMAL(4,0)  COMMENT  '天数',
  L_YEZFBZ  STRING  COMMENT  '余额正负标志',
  VC_JZZQ  STRING  COMMENT  '结转周期',
  L_RQLX  STRING  COMMENT  '日期类型',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  VC_JZLX  STRING  COMMENT  '结转类型',
  L_KMMS  DECIMAL(1,0)  COMMENT  '科目模式',
  VC_LLR  STRING  COMMENT  '',
  VC_JYRLX  STRING  COMMENT  ''
)
COMMENT '清算库结转'
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
                                   , L_ZTBH
                                   , VC_ZY
                                   , VC_DYKM
                                   , VC_JFKM
                                   , VC_DFKM
                                   , L_TS
                                   , L_YEZFBZ
                                   , VC_JZZQ
                                   , L_RQLX
                                   , L_YWLB
                                   , VC_JZLX
                                   , L_KMMS
                                   , VC_LLR
                                   , VC_JYRLX
                                FROM ${hsfa_src_schema}.TQSKJZ"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_ZY", "type": "STRING"}, {"name": "VC_DYKM", "type": "STRING"}, {"name": "VC_JFKM", "type": "STRING"}, {"name": "VC_DFKM", "type": "STRING"}, {"name": "L_TS", "type": "DOUBLE"}, {"name": "L_YEZFBZ", "type": "DOUBLE"}, {"name": "VC_JZZQ", "type": "STRING"}, {"name": "L_RQLX", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "VC_JZLX", "type": "STRING"}, {"name": "L_KMMS", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_JYRLX", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tqskjz_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tqskjz_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tqskjz_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tqskjz_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TQSKJZ_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TQSKJZ_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tqskjz_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSKJZ_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BH
     , L_ZTBH
     , VC_ZY
     , VC_DYKM
     , VC_JFKM
     , VC_DFKM
     , L_TS
     , L_YEZFBZ
     , VC_JZZQ
     , L_RQLX
     , L_YWLB
     , VC_JZLX
     , L_KMMS
     , VC_LLR
     , VC_JYRLX
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TQSKJZ_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSKJZ_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TQSKJZ_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TQSKJZ_PFD成功"
      exit 0
   fi
fi
