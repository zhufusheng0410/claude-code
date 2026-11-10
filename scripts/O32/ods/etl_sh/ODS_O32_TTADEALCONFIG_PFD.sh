#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTADEALCONFIG_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTADEALCONFIG_PFD_TMP(
  L_TADEAL_SERIALNO  STRING  COMMENT  'ta接口数据处理模式编号',
  VC_CONFIG_CAPTION  STRING  COMMENT  'ta接口数据处理模式名称',
  C_APPLY_DEALTIME  STRING  COMMENT  '申购冲现时点',
  C_REDEEM_DEALTIME  STRING  COMMENT  '赎回冲现时点',
  C_FROZENBALANCE_TYPE  STRING  COMMENT  '冻结金额',
  C_FROZEN_TIME  STRING  COMMENT  '冻结时点',
  C_APPLY_ENABLETIME  STRING  COMMENT  '申购款计入可用时点',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  L_FROZEN_DAY  DECIMAL(2,0)  COMMENT  't-n日冻结',
  C_REDEEM_ENABLETIME  STRING  COMMENT  '赎回款计入可用时点'
)
COMMENT 'ta接口数据处理模板表'
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
              "querySql": ["SELECT  L_TADEAL_SERIALNO
                                   , VC_CONFIG_CAPTION
                                   , C_APPLY_DEALTIME
                                   , C_REDEEM_DEALTIME
                                   , C_FROZENBALANCE_TYPE
                                   , C_FROZEN_TIME
                                   , C_APPLY_ENABLETIME
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , L_FROZEN_DAY
                                   , C_REDEEM_ENABLETIME
                                FROM ${o32_src_schema}.TTADEALCONFIG"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_TADEAL_SERIALNO", "type": "DOUBLE"}, {"name": "VC_CONFIG_CAPTION", "type": "STRING"}, {"name": "C_APPLY_DEALTIME", "type": "STRING"}, {"name": "C_REDEEM_DEALTIME", "type": "STRING"}, {"name": "C_FROZENBALANCE_TYPE", "type": "STRING"}, {"name": "C_FROZEN_TIME", "type": "STRING"}, {"name": "C_APPLY_ENABLETIME", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "L_FROZEN_DAY", "type": "DOUBLE"}, {"name": "C_REDEEM_ENABLETIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttadealconfig_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttadealconfig_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttadealconfig_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttadealconfig_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTADEALCONFIG_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTADEALCONFIG_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttadealconfig_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTADEALCONFIG_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_TADEAL_SERIALNO
     , VC_CONFIG_CAPTION
     , C_APPLY_DEALTIME
     , C_REDEEM_DEALTIME
     , C_FROZENBALANCE_TYPE
     , C_FROZEN_TIME
     , C_APPLY_ENABLETIME
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , L_FROZEN_DAY
     , C_REDEEM_ENABLETIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TTADEALCONFIG_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTADEALCONFIG_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTADEALCONFIG_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTADEALCONFIG_PFD成功"
      exit 0
   fi
fi
