#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYSEAT_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYSEAT_PFD_TMP(
  L_IDNO  STRING  COMMENT  '编号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_SEAT  STRING  COMMENT  '席位编码',
  C_BOURSEFLAG  STRING  COMMENT  '交易所标志',
  C_SEATNAME  STRING  COMMENT  '席位名称',
  D_INPUTDATE  STRING  COMMENT  '输入日期',
  C_SOURCETYPE  STRING  COMMENT  '份额来源',
  C_TRANSFERPERMITFLAG  STRING  COMMENT  '',
  D_DOWNLOADDATE  STRING  COMMENT  ''
)
COMMENT '销售商席位对照_中登'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  L_IDNO
                                   , C_AGENCYNO
                                   , C_SEAT
                                   , C_BOURSEFLAG
                                   , C_SEATNAME
                                   , D_INPUTDATE
                                   , C_SOURCETYPE
                                   , C_TRANSFERPERMITFLAG
                                   , D_DOWNLOADDATE
                                FROM ${hsfta_src_schema}.TAGENCYSEAT"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_IDNO", "type": "DOUBLE"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_SEAT", "type": "STRING"}, {"name": "C_BOURSEFLAG", "type": "STRING"}, {"name": "C_SEATNAME", "type": "STRING"}, {"name": "D_INPUTDATE", "type": "STRING"}, {"name": "C_SOURCETYPE", "type": "STRING"}, {"name": "C_TRANSFERPERMITFLAG", "type": "STRING"}, {"name": "D_DOWNLOADDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tagencyseat_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tagencyseat_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tagencyseat_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tagencyseat_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TAGENCYSEAT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TAGENCYSEAT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tagencyseat_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYSEAT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_IDNO
     , C_AGENCYNO
     , C_SEAT
     , C_BOURSEFLAG
     , C_SEATNAME
     , D_INPUTDATE
     , C_SOURCETYPE
     , C_TRANSFERPERMITFLAG
     , D_DOWNLOADDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYSEAT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYSEAT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TAGENCYSEAT_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TAGENCYSEAT_PFD成功"
      exit 0
   fi
fi
