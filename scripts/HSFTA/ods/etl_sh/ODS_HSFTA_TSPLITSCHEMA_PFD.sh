#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TSPLITSCHEMA_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSPLITSCHEMA_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  D_CDATE  STRING  COMMENT  '拆分处理日',
  F_UNITSPLIT  DECIMAL(12,9)  COMMENT  '每单位拆分份额',
  C_DESCRIBE  STRING  COMMENT  '方案描述',
  C_DEALFLAG  STRING  COMMENT  '拆分处理标志',
  F_UNITPROFIT  DECIMAL(7,4)  COMMENT  '折算成的每单位分红',
  F_TOTALBONUS  DECIMAL(16,8)  COMMENT  '拆分前的累计分红',
  C_MEMO  STRING  COMMENT  '备注',
  C_SPLITTYPE  STRING  COMMENT  '拆分方式',
  F_FUNDASSET  DECIMAL(16,2)  COMMENT  '拆分的基金资产',
  F_ORISHARES  DECIMAL(16,2)  COMMENT  '原确认份额',
  C_FLAG  STRING  COMMENT  '是否已经发起',
  C_OTHERCODE  STRING  COMMENT  '对方基金代码',
  F_FOLLOWNETVALUE  DECIMAL(7,4)  COMMENT  '',
  C_ISSPLITTOOTHERFUND  STRING  COMMENT  '',
  C_DEALALLSHARESREDEEM  STRING  COMMENT  '是否判断全部赎回',
  C_NEGATIVESPLITREDUCETYPE  STRING  COMMENT  '',
  C_POSITIVESPLITDETAILDEAL  STRING  COMMENT  '',
  C_SHAREBATCHMODEL  STRING  COMMENT  '',
  C_ISREDEEMALLAFTERSPTDAY  STRING  COMMENT  '',
  F_UNITREMAINSHARES  DECIMAL(12,9)  COMMENT  '',
  C_POSITIVESPLITTYPE  STRING  COMMENT  '',
  C_REDEEMSPLITSHARES  STRING  COMMENT  '',
  C_INCLUDESHLOF  STRING  COMMENT  ''
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , TO_CHAR(D_CDATE,'YYYYMMDD') D_CDATE
                                   , F_UNITSPLIT
                                   , C_DESCRIBE
                                   , C_DEALFLAG
                                   , F_UNITPROFIT
                                   , F_TOTALBONUS
                                   , C_MEMO
                                   , C_SPLITTYPE
                                   , F_FUNDASSET
                                   , F_ORISHARES
                                   , C_FLAG
                                   , C_OTHERCODE
                                   , F_FOLLOWNETVALUE
                                   , C_ISSPLITTOOTHERFUND
                                   , C_DEALALLSHARESREDEEM
                                   , C_NEGATIVESPLITREDUCETYPE
                                   , C_POSITIVESPLITDETAILDEAL
                                   , C_SHAREBATCHMODEL
                                   , C_ISREDEEMALLAFTERSPTDAY
                                   , F_UNITREMAINSHARES
                                   , C_POSITIVESPLITTYPE
                                   , C_REDEEMSPLITSHARES
                                   , C_INCLUDESHLOF
                                FROM ${hsfta_src_schema}.TSPLITSCHEMA"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "D_CDATE", "type": "STRING"}, {"name": "F_UNITSPLIT", "type": "DOUBLE"}, {"name": "C_DESCRIBE", "type": "STRING"}, {"name": "C_DEALFLAG", "type": "STRING"}, {"name": "F_UNITPROFIT", "type": "DOUBLE"}, {"name": "F_TOTALBONUS", "type": "DOUBLE"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_SPLITTYPE", "type": "STRING"}, {"name": "F_FUNDASSET", "type": "DOUBLE"}, {"name": "F_ORISHARES", "type": "DOUBLE"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "C_OTHERCODE", "type": "STRING"}, {"name": "F_FOLLOWNETVALUE", "type": "DOUBLE"}, {"name": "C_ISSPLITTOOTHERFUND", "type": "STRING"}, {"name": "C_DEALALLSHARESREDEEM", "type": "STRING"}, {"name": "C_NEGATIVESPLITREDUCETYPE", "type": "STRING"}, {"name": "C_POSITIVESPLITDETAILDEAL", "type": "STRING"}, {"name": "C_SHAREBATCHMODEL", "type": "STRING"}, {"name": "C_ISREDEEMALLAFTERSPTDAY", "type": "STRING"}, {"name": "F_UNITREMAINSHARES", "type": "DOUBLE"}, {"name": "C_POSITIVESPLITTYPE", "type": "STRING"}, {"name": "C_REDEEMSPLITSHARES", "type": "STRING"}, {"name": "C_INCLUDESHLOF", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tsplitschema_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tsplitschema_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tsplitschema_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tsplitschema_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TSPLITSCHEMA_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TSPLITSCHEMA_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tsplitschema_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSPLITSCHEMA_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , D_CDATE
     , F_UNITSPLIT
     , C_DESCRIBE
     , C_DEALFLAG
     , F_UNITPROFIT
     , F_TOTALBONUS
     , C_MEMO
     , C_SPLITTYPE
     , F_FUNDASSET
     , F_ORISHARES
     , C_FLAG
     , C_OTHERCODE
     , F_FOLLOWNETVALUE
     , C_ISSPLITTOOTHERFUND
     , C_DEALALLSHARESREDEEM
     , C_NEGATIVESPLITREDUCETYPE
     , C_POSITIVESPLITDETAILDEAL
     , C_SHAREBATCHMODEL
     , C_ISREDEEMALLAFTERSPTDAY
     , F_UNITREMAINSHARES
     , C_POSITIVESPLITTYPE
     , C_REDEEMSPLITSHARES
     , C_INCLUDESHLOF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSPLITSCHEMA_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSPLITSCHEMA_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TSPLITSCHEMA_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TSPLITSCHEMA_PFD成功"
      exit 0
   fi
fi
