#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTHIRDPARTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTHIRDPARTINFO_PFD_TMP(
  L_THIRDPART_NO  DECIMAL(8,0)  COMMENT  '机构序号',
  VC_THIRDPART_CODE  STRING  COMMENT  '机构代码',
  VC_THIRDPART_NAME  STRING  COMMENT  '机构名称',
  VC_THIRDPART_FULLNAME  STRING  COMMENT  '机构全称',
  VC_CONTACT  STRING  COMMENT  '联系方式',
  VC_PHONE  STRING  COMMENT  '联系电话',
  VC_FAX  STRING  COMMENT  '传真',
  VC_REMARK  STRING  COMMENT  '备注',
  C_TRADE_TYPE  STRING  COMMENT  '接入类型',
  L_RC_CONNECT_COUNT  DECIMAL(4,0)  COMMENT  '远程客户端最大连接数',
  L_UFX_CONNECT_COUNT  DECIMAL(4,0)  COMMENT  'ufx最大连接数'
)
COMMENT '三方机构信息表'
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
              "querySql": ["SELECT  L_THIRDPART_NO
                                   , VC_THIRDPART_CODE
                                   , VC_THIRDPART_NAME
                                   , VC_THIRDPART_FULLNAME
                                   , VC_CONTACT
                                   , VC_PHONE
                                   , VC_FAX
                                   , VC_REMARK
                                   , C_TRADE_TYPE
                                   , L_RC_CONNECT_COUNT
                                   , L_UFX_CONNECT_COUNT
                                FROM ${o32_src_schema}.TTHIRDPARTINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_THIRDPART_NO", "type": "DOUBLE"}, {"name": "VC_THIRDPART_CODE", "type": "STRING"}, {"name": "VC_THIRDPART_NAME", "type": "STRING"}, {"name": "VC_THIRDPART_FULLNAME", "type": "STRING"}, {"name": "VC_CONTACT", "type": "STRING"}, {"name": "VC_PHONE", "type": "STRING"}, {"name": "VC_FAX", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_TRADE_TYPE", "type": "STRING"}, {"name": "L_RC_CONNECT_COUNT", "type": "DOUBLE"}, {"name": "L_UFX_CONNECT_COUNT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tthirdpartinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tthirdpartinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tthirdpartinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tthirdpartinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTHIRDPARTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTHIRDPARTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tthirdpartinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTHIRDPARTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_THIRDPART_NO
     , VC_THIRDPART_CODE
     , VC_THIRDPART_NAME
     , VC_THIRDPART_FULLNAME
     , VC_CONTACT
     , VC_PHONE
     , VC_FAX
     , VC_REMARK
     , C_TRADE_TYPE
     , L_RC_CONNECT_COUNT
     , L_UFX_CONNECT_COUNT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TTHIRDPARTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTHIRDPARTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTHIRDPARTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTHIRDPARTINFO_PFD成功"
      exit 0
   fi
fi
