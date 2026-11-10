#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TSPLITSCHEMA_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSPLITSCHEMA_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  D_CDATE  STRING  COMMENT  '拆分处理日',
  F_UNITSPLIT  DECIMAL(12,9)  COMMENT  '每单位拆分份额',
  C_DEALFLAG  STRING  COMMENT  '拆分处理标志',
  F_NETVALUE  DECIMAL(16,8)  COMMENT  '基金净值（成交价）',
  C_SPLITTYPE  STRING  COMMENT  '拆分方式',
  F_FUNDASSET  DECIMAL(16,2)  COMMENT  '拆分的基金资产',
  F_TAILDEALTYPE  STRING  COMMENT  '',
  F_TAIL  DECIMAL(7,2)  COMMENT  '尾差金额',
  C_OTHERCODE  STRING  COMMENT  '对方基金代码',
  C_DEALALLSHARESREDEEM  STRING  COMMENT  '是否判断全部赎回',
  C_ISDEALTAIL  STRING  COMMENT  '是否处理尾差',
  C_SPLITSHARESREDEEM  STRING  COMMENT  '',
  C_ADDSPLITSHARESTYPE  STRING  COMMENT  '',
  C_SPLITSHARECALFEE  STRING  COMMENT  ''
)
COMMENT '基金拆分方案'
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , D_CDATE
                                   , F_UNITSPLIT
                                   , C_DEALFLAG
                                   , F_NETVALUE
                                   , C_SPLITTYPE
                                   , F_FUNDASSET
                                   , F_TAILDEALTYPE
                                   , F_TAIL
                                   , C_OTHERCODE
                                   , C_DEALALLSHARESREDEEM
                                   , C_ISDEALTAIL
                                   , C_SPLITSHARESREDEEM
                                   , C_ADDSPLITSHARESTYPE
                                   , C_SPLITSHARECALFEE
                                FROM ${hszta_src_schema}.TSPLITSCHEMA"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "F_UNITSPLIT", "type": "DOUBLE"}, {"name": "C_DEALFLAG", "type": "STRING"}, {"name": "F_NETVALUE", "type": "DOUBLE"}, {"name": "C_SPLITTYPE", "type": "STRING"}, {"name": "F_FUNDASSET", "type": "DOUBLE"}, {"name": "F_TAILDEALTYPE", "type": "STRING"}, {"name": "F_TAIL", "type": "DOUBLE"}, {"name": "C_OTHERCODE", "type": "STRING"}, {"name": "C_DEALALLSHARESREDEEM", "type": "STRING"}, {"name": "C_ISDEALTAIL", "type": "STRING"}, {"name": "C_SPLITSHARESREDEEM", "type": "STRING"}, {"name": "C_ADDSPLITSHARESTYPE", "type": "STRING"}, {"name": "C_SPLITSHARECALFEE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tsplitschema_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tsplitschema_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tsplitschema_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tsplitschema_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TSPLITSCHEMA_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TSPLITSCHEMA_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tsplitschema_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSPLITSCHEMA_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , D_CDATE
     , F_UNITSPLIT
     , C_DEALFLAG
     , F_NETVALUE
     , C_SPLITTYPE
     , F_FUNDASSET
     , F_TAILDEALTYPE
     , F_TAIL
     , C_OTHERCODE
     , C_DEALALLSHARESREDEEM
     , C_ISDEALTAIL
     , C_SPLITSHARESREDEEM
     , C_ADDSPLITSHARESTYPE
     , C_SPLITSHARECALFEE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSPLITSCHEMA_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSPLITSCHEMA_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TSPLITSCHEMA_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TSPLITSCHEMA_PFD成功"
      exit 0
   fi
fi
