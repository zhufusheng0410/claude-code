#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TTURNSETS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TTURNSETS_PFD_TMP(
  VC_DYKM  STRING  COMMENT  '对应科目',
  VC_DFKM  STRING  COMMENT  '贷方科目',
  L_FUNDID  STRING  COMMENT  '帐套编号',
  L_ROW  DECIMAL(10,0)  COMMENT  '行号',
  VC_JFKM  STRING  COMMENT  '借方科目',
  VC_ZY  STRING  COMMENT  '摘要',
  VC_JZLX  STRING  COMMENT  '结转类型',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  L_KMMS  DECIMAL(1,0)  COMMENT  '科目模式',
  L_LBMX  DECIMAL(4,0)  COMMENT  '费用类别',
  EN_ZFBL  DECIMAL(19,6)  COMMENT  '支付比例',
  L_JSFS  DECIMAL(1,0)  COMMENT  '',
  L_PL  DECIMAL(2,0)  COMMENT  '',
  VC_TS  STRING  COMMENT  '',
  L_RQMS  DECIMAL(2,0)  COMMENT  '',
  D_BEGIN  STRING  COMMENT  '',
  D_END  STRING  COMMENT  ''
)
COMMENT '手工结转设置'
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
              "querySql": ["SELECT  VC_DYKM
                                   , VC_DFKM
                                   , L_FUNDID
                                   , L_ROW
                                   , VC_JFKM
                                   , VC_ZY
                                   , VC_JZLX
                                   , L_YWLB
                                   , L_KMMS
                                   , L_LBMX
                                   , EN_ZFBL
                                   , L_JSFS
                                   , L_PL
                                   , VC_TS
                                   , L_RQMS
                                   , D_BEGIN
                                   , D_END
                                FROM ${hsfa_src_schema}.TTURNSETS"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_DYKM", "type": "STRING"}, {"name": "VC_DFKM", "type": "STRING"}, {"name": "L_FUNDID", "type": "DOUBLE"}, {"name": "L_ROW", "type": "DOUBLE"}, {"name": "VC_JFKM", "type": "STRING"}, {"name": "VC_ZY", "type": "STRING"}, {"name": "VC_JZLX", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_KMMS", "type": "DOUBLE"}, {"name": "L_LBMX", "type": "DOUBLE"}, {"name": "EN_ZFBL", "type": "DOUBLE"}, {"name": "L_JSFS", "type": "DOUBLE"}, {"name": "L_PL", "type": "DOUBLE"}, {"name": "VC_TS", "type": "STRING"}, {"name": "L_RQMS", "type": "DOUBLE"}, {"name": "D_BEGIN", "type": "STRING"}, {"name": "D_END", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tturnsets_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tturnsets_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tturnsets_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tturnsets_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TTURNSETS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TTURNSETS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tturnsets_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TTURNSETS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_DYKM
     , VC_DFKM
     , L_FUNDID
     , L_ROW
     , VC_JFKM
     , VC_ZY
     , VC_JZLX
     , L_YWLB
     , L_KMMS
     , L_LBMX
     , EN_ZFBL
     , L_JSFS
     , L_PL
     , VC_TS
     , L_RQMS
     , D_BEGIN
     , D_END
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TTURNSETS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TTURNSETS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TTURNSETS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TTURNSETS_PFD成功"
      exit 0
   fi
fi
